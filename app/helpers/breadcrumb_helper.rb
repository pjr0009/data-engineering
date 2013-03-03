module BreadcrumbHelper
  def breadcrumbs
    @breadcrumb ||= [ { :title => 'Dashboard', :url => root_url } ]
  end

  def breadcrumb_add(title, url)
    breadcrumbs << { :title => title, :url => url }
  end

  def render_breadcrumb
    render :partial => 'layout/breadcrumb', :locals => { :breadcrumbs => breadcrumbs }
  end
end