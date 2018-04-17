module Greedo
  module GridHelper
    class Grid
      attr_accessor :paginator
      attr_reader :view_context, :fields, :presenter, :empty_message_text,
        :order, :order_by

      def initialize(view_context:, order: nil, order_by: nil)
        @view_context = view_context
        @row_id = ->(record) { default_row_id(record) }
        @fields = []
        @presenter = proc{|r| r}
        @empty_message_text = "No data to show."
        @order = order
        @order_by = order_by
      end

      def configure
        yield self if block_given?
      end

      def custom_empty_message(empty_message_text)
        @empty_message_text = empty_message_text
        nil
      end

      def ordered_by
        fields.find(&:ordered_by?) || Field.new
      end

      def row_id(&block)
        @row_id = block
        nil
      end

      def column(name, label: name.to_s.humanize, sort: nil, &block)
        if sort.blank? && name.is_a?(Symbol)
          sort = name.to_s
        end
        if block
          renderer = ->(record) { view_context.capture(present(record), &block) }
        else
          renderer = ->(record) { present(record).public_send(name) }
        end

        fields << Field.new(name, label, renderer, order, order_by, view_context, sort)
        nil
      end

      def presenter(klass = nil, &block)
        block = proc{|r| klass.new(r)} if klass
        @presenter = block
        nil
      end

      def present(record)
        @presenter.call(record)
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
        view_context.content_tag(:p) { empty_message_text }
      end

      private

      def records
        paginator.records
      end

      def default_row_id(record)
        snake_class = record.class.name.underscore.gsub("_", "-")
        "#{snake_class}-#{record.id}"
      end

      Column = Struct.new(:value, :klass)

      Row = Struct.new(:record, :row_id, :fields) do
        def id
          row_id.call(record)
        end

        def columns
          fields.map{ |f| Column.new(f.value(record), f.klass) }
        end
      end

      Field = Struct.new(:name, :label, :renderer, :order, :order_by, :view_context, :sort) do
        def value(record)
          renderer.call(record)
        end

        def klass
          label.parameterize.underscore
        end

        def ordered_by?
          order_by == name.to_s && %w(asc desc).include?(order)
        end

        def order_desc_path
          if ordered_by? && order == "desc"
            view_context.url_for
          else
            view_context.url_for(order: :desc, order_by: name)
          end
        end

        def order_asc_path
          if ordered_by? && order == "asc"
            view_context.url_for
          else
            view_context.url_for(order: :asc, order_by: name)
          end
        end

        def order_desc_class
          if ordered_by? && order == "desc"
            "glyphicon-triangle-bottom"
          else
            "glyphicon-chevron-down"
          end
        end

        def order_asc_class
          if ordered_by? && order == "asc"
            "glyphicon-triangle-top"
          else
            "glyphicon-chevron-up"
          end
        end
      end
    end

    def greedo(scope,
               param_name: :page,
               page: params.fetch(param_name) { 1 }.to_i,
               per_page: 20,
               order: params[:order],
               order_by: params[:order_by],
               &block)
      grid = Grid.new(view_context: self, order: order, order_by: order_by)
      grid.configure(&block)
      grid.paginator = Paginator.build(scope,
                                       page: page,
                                       per_page: per_page,
                                       order_by: grid.ordered_by)
      render partial: "greedo/grid", locals: {grid: grid, param_name: param_name}
    end
  end
end
