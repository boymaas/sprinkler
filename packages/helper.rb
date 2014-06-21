class ConfigurationError < RuntimeError; end

def asset_path path
  absolute_path = File.expand_path( File.join(File.dirname(__FILE__), '..', 'assets', path) )
end

def config(name, opts={})
  default  = opts.fetch(:default, nil)
  regexp   = opts.fetch(:regexp, nil)
  required = opts.fetch(:required, true)

  value = ENV[name.to_s] || default
  if required && !value.present?
    raise ConfigurationError, "required value for dotenv value #{name}"
  end
  if regexp && value && !regexp.match(value)
    raise ConfigurationError, "invalid value for #{name}: #{value.inspect}"
  end
  value
end

def load_packages *packages
  packages.each do |package|
    require_relative package.to_s
  end
end
