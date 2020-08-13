# this is test
require 'httparty'

class Post
  include HTTParty
  base_uri 'https://jsonplaceholder.typicode.com/posts'

  class RecordNotFoundError < StandardError; end

  class << self
    def all
      res = get '/'
      res.parsed_response.map do |post_hash|
        self.new(post_hash)
      end
    end

    def find(id)
      res = get("/#{id}")
      raise RecordNotFoundError if res.not_found?
      self.new(res.parsed_response)
    end
  end

  attr_accessor :attrs

  def initialize(attrs = {})
    @attrs = attrs.dup.transform_keys(&:to_sym)
  end

  # assume create is like #save in AR
  def create
    res = self.class.post('/', body: attrs)
    res.created?
  end

  def update(new_attrs = {})
    new_attrs = new_attrs.dup.transform_keys(&:to_sym)
    new_attrs.delete(:id)
    attrs.merge!(new_attrs)
    res = self.class.put("/#{attrs[:id]}", body: attrs)
    res.ok?
  end

  def destroy
    res = self.class.delete("/#{attrs[:id]}")
    res.ok?
  end

end


