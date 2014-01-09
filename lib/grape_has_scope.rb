module GrapeHasScope
  TRUE_VALUES = ["true", true, "1", 1]

  ALLOWED_TYPES = {
    :array   => [ Array ],
    :hash    => [ Hash ],
    :boolean => [ Object ],
    :default => [ String, Numeric ]
  }

  def self.included(base)
    base.class_eval do
      attr_accessor :scopes_configuration
    end
  end

  def has_scope(*scopes, &block)
    options = scopes.extract_options!
    options.symbolize_keys!
    options.assert_valid_keys(:type, :only, :except, :if, :unless, :default, :as, :using, :allow_blank)

    if options.key?(:using)
      if options.key?(:type) && options[:type] != :hash
        raise "You cannot use :using with another :type different than :hash"
      else
        options[:type] = :hash
      end

      options[:using] = Array(options[:using])
    end

    options[:only]   = Array(options[:only])
    options[:except] = Array(options[:except])

    @scopes_configuration = (@scopes_configuration || {}).dup

    scopes.each do |scope|
      @scopes_configuration[scope] ||= { :as => scope, :type => :default, :block => block }
      @scopes_configuration[scope] = @scopes_configuration[scope].merge(options)
    end
  end

  # Receives an object where scopes will be applied to.
  #
  #   class GraduationsController < InheritedResources::Base
  #     has_scope :featured, :type => true, :only => :index
  #     has_scope :by_degree, :only => :index
  #
  #     def index
  #       @graduations = apply_scopes(Graduation).all
  #     end
  #   end
  #
  def apply_scopes(target, hash=params)
    return target unless scopes_configuration

    @scopes_configuration.each do |scope, options|
      next unless apply_scope_to_action?(options)
      key = options[:as]

      if hash.key?(key)
        value, call_scope = hash[key], true
      elsif options.key?(:default)
        value, call_scope = options[:default], true
        value = value.call(self) if value.is_a?(Proc)
      end

      value = parse_value(options[:type], key, value)
      value = normalize_blanks(value)

      if call_scope && (value.present? || options[:allow_blank])
        current_scopes[key] = value
        target = call_scope_by_type(options[:type], scope, target, value, options)
      end
    end

    target
  end

  # Set the real value for the current scope if type check.
  def parse_value(type, key, value) #:nodoc:
    if type == :boolean
      TRUE_VALUES.include?(value)
    elsif value && ALLOWED_TYPES[type].any?{ |klass| value.is_a?(klass) }
      value
    end
  end

  # Screens pseudo-blank params.
  def normalize_blanks(value) #:nodoc:
    return value if value.nil?
    if value.is_a?(Array)
      value.select { |v| v.present? }
    elsif value.is_a?(Hash)
      value.select { |k, v| normalize_blanks(v).present? }.with_indifferent_access
    else
      value
    end
  end

  # Call the scope taking into account its type.
  def call_scope_by_type(type, scope, target, value, options) #:nodoc:
    block = options[:block]

    if type == :boolean
      block ? block.call(self, target) : target.send(scope)
    elsif value && options.key?(:using)
      value = value.values_at(*options[:using])
      block ? block.call(self, target, value) : target.send(scope, *value)
    else
      block ? block.call(self, target, value) : target.send(scope, value)
    end
  end

  # Given an options with :only and :except arrays, check if the scope
  # can be performed in the current action.
  def apply_scope_to_action?(options) #:nodoc:
    return false unless applicable?(options[:if], true) && applicable?(options[:unless], false)

    if options[:only].empty?
      options[:except].empty? || !options[:except].include?(action_name.to_sym)
    else
      options[:only].include?(action_name.to_sym)
    end
  end

  # Evaluates the scope options :if or :unless. Returns true if the proc
  # method, or string evals to the expected value.
  def applicable?(string_proc_or_symbol, expected) #:nodoc:
    case string_proc_or_symbol
      when String
        eval(string_proc_or_symbol) == expected
      when Proc
        string_proc_or_symbol.call(self) == expected
      when Symbol
        send(string_proc_or_symbol) == expected
      else
        true
    end
  end

  # Returns the scopes used in this action.
  def current_scopes
    @current_scopes ||= {}
  end
end

class Grape::Endpoint
  include GrapeHasScope
end