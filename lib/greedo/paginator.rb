require "will_paginate"
require "will_paginate-bootstrap"

module Greedo
  class Paginator
    attr_reader :scope, :page, :per_page, :order, :order_by

    def self.build(scope,
                   params: {},
                   page: params.fetch(:page) { 1 }.to_i,
                   per_page: params.fetch(:per_page) { 20 }.to_i,
                   order: nil,
                   order_by: nil)
      return ArrayPaginator.new(scope, order, order_by) if scope.is_a?(Array)
      Paginator.new(scope, page: page, per_page: per_page)
    end

    def initialize(scope, page:, per_page:, order: nil, order_by: nil)
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
    attr_reader :order, :order_by

    def initialize(records, order, order_by)
      @records = records
      @order = order
      @order_by = order_by
    end

    def records
      @sorted_records ||= sort_records
    end

    def show?
      false
    end

    private

    def sort_records
      sorted = order_by ? @records.sort_by { |r| r.send(order_by) } : @records

      order == "desc" ? sorted.reverse : sorted
    end
  end
end
