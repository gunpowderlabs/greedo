require "will_paginate"
require "will_paginate-bootstrap"

module Greedo
  class Paginator
    attr_reader :scope, :page, :per_page

    def self.build(scope,
                   params: {},
                   page: params.fetch(:page) { 1 }.to_i,
                   per_page: params.fetch(:per_page) { 20 }.to_i)
      return ArrayPaginator.new(scope) if scope.is_a?(Array)
      Paginator.new(scope, page: page, per_page: per_page)
    end

    def initialize(scope, page:, per_page:)
      @scope = scope
      @page = page
      @per_page = per_page
    end

    def records
      scope.paginate(page: page, per_page: per_page)
    end

    def show?
      scope.count > per_page
    end
  end

  class ArrayPaginator
    attr_reader :records

    def initialize(records)
      @records = records
    end

    def show?
      false
    end
  end
end
