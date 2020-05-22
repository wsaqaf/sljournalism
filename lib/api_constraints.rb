class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || req.headers['Accept'].includes?("application/vnd.faktaassistenten.v#{@version}")
  end
end
