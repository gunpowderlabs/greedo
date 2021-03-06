require "spec_helper"

RSpec.describe Greedo::GridHelper, type: :helper do
  it "renders a table" do
    create_project(name: "Foo")

    html = helper.greedo(Project.all)

    expect(html).to have_selector("table.table.table-striped")
  end

  it "renders a column header for each column specified" do
    create_project(name: "Foo")

    html = helper.greedo(Project.all) do |g|
      g.column :id, label: "ID", sort: false
      g.column :name, sort: false
    end

    expect(html).to include("ID")
    expect(html).to include("Name")
  end

  it "renders values for each of the columns specified" do
    foo = create_project(name: "Foo")
    bar = create_project(name: "Bar")

    html = helper.greedo(Project.all) do |g|
      g.column :id, label: "ID", sort: false
      g.column :name, sort: false
    end

    expect(html).to include("Foo")
    expect(html).to include(foo.id.to_s)
    expect(html).to include("Bar")
    expect(html).to include(bar.id.to_s)
  end

  it "allows customizing how the content will be displayed" do
    create_project(name: "Foo")

    html = helper.greedo(Project.all) do |g|
      g.column "Name" do |p|
        p.name.upcase
      end
    end

    expect(html).to include("FOO")
  end

  it "adds pagination" do
    create_project(name: "Bar")
    create_project(name: "Baz")
    create_project(name: "Foo")

    params[:controller] = "projects"
    html = helper.greedo(Project.all, per_page: 2) do |g|
      g.column :id
      g.column :name
    end

    expect(html).not_to include("Foo")
    expect(html).to include("Bar")
    expect(html).to include("Baz")
  end

  it "allows changing the page param name" do
    create_project(name: "Bar")
    create_project(name: "Baz")
    create_project(name: "Foo")

    params[:controller] = "projects"
    params[:foo_page] = "2"
    html = helper.greedo(Project.all, param_name: :foo_page, per_page: 2) do |g|
      g.column :id
      g.column :name
    end

    expect(html).to include("Foo")
    expect(html).not_to include("Bar")
    expect(html).not_to include("Baz")
  end

  it "adds row id" do
    foo = create_project(name: "foo")
    bar = create_project(name: "Bar")

    html = helper.greedo(Project.all) do |g|
      g.column :id, sort: false
      g.column :name, sort: false
    end

    expect(html).to have_selector("tr#project-#{foo.id}")
    expect(html).to have_selector("tr#project-#{bar.id}")
  end

  it "adds custom row id" do
    foo = create_project(name: "foo")
    bar = create_project(name: "Bar")

    html = helper.greedo(Project.all) do |g|
      g.row_id { |p| "asdf-#{p.id}" }
      g.column :id, sort: false
      g.column :name, sort: false
    end

    expect(html).to have_selector("tr#asdf-#{foo.id}")
    expect(html).to have_selector("tr#asdf-#{bar.id}")
  end

  it "show a no records message" do
    html = helper.greedo(Project.all) do |g|
      g.column :id
    end

    expect(html).to include("No data to show.")
  end

  class ProjectPresenter < SimpleDelegator
    def author
      "No Author"
    end
  end

  it "wraps items in presenter" do
    create_project(name: "foo")

    html = helper.greedo(Project.all) do |g|
      g.presenter ProjectPresenter
      g.column :author, sort: false
    end

    expect(html).to include("No Author")
  end

  it "wraps items in a block presenter" do
    create_project(name: "foo")

    html = helper.greedo(Project.all) do |g|
      g.presenter do |record|
        record.name
      end

      g.column :length, sort: false
    end

    expect(html).to include("3")
  end

  it "does not pollute the output when printing the presenter output" do
    helper.greedo(Project.all) do |g|
      expect(g.presenter {|r| r.name}).to be_nil
    end
  end

  def create_project(attrs = {})
    Project.create!({
      name: "Project #{Project.count + 1}"
    }.merge(attrs))
  end
end
