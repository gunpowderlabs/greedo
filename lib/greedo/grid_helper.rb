module Greedo
  module GridHelper
    class Grid
      attr_reader :paginator, :view_context, :fields

      def initialize(paginator, view_context)
        @paginator = paginator
        @view_context = view_context
        @row_id = ->(record) { default_row_id(record) }
        @fields = []
      end

      def configure
        yield self if block_given?
      end

      def row_id(&block)
        @row_id = block
        nil
      end

      def column(name, label: name.to_s.humanize, &block)
        if block
          renderer = ->(record) { view_context.capture(record, &block) }
        else
          renderer = ->(record) { record.public_send(name) }
        end

        fields << Field.new(name, label, renderer)
        nil
      end

      def rows
        records.map do |record|
          Row.new(record, @row_id, fields)
        end
      end

      def headers
        fields
      end

      def empty?
        records.empty?
      end

      def show_pagination?
        paginator.show?
      end

      def empty_message
        view_context.content_tag(:p) { "No data to show." }
      end

      private

      def records
        paginator.records
      end

      def default_row_id(record)
        snake_class = record.class.name.underscore.gsub("_", "-")
        "#{snake_class}-#{record.id}"
      end

      Column = Struct.new(:value)

      Row = Struct.new(:record, :row_id, :fields) do
        def id
          row_id.call(record)
        end

        def columns
          fields.map{ |f| Column.new(f.value(record)) }
        end
      end

      Field = Struct.new(:name, :label, :renderer) do
        def value(record)
          renderer.call(record)
        end
      end
    end

    def greedo(scope,
               param_name: :page,
               page: params.fetch(param_name) { 1 }.to_i,
               per_page: 20,
               &block)
      paginator = Paginator.build(scope, page: page, per_page: per_page)
      grid = Grid.new(paginator, self)
      grid.configure(&block)
      render partial: "greedo/grid", locals: {grid: grid, param_name: param_name}
    end
  end
end
