# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def link_to_onmousedown(name, options = {}, html_options = nil, *parameters_for_method_reference)
    html_options = Hash.new if html_options.nil?
    html_options["onMouseDown"]="this.style.backgroundColor='lightblue';document.location=this.href"
    html_options["onClick"]="return false" #if we don't do this we get double clicks
    link = link_to(name, options, html_options, *parameters_for_method_reference)
  end
end
