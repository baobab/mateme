# We use this chunk of controller code all over to generate PDF files.
#
# To stay DRY we placed it here instead of repeating it all over the place.
#
module PdfHelper
  require 'prince'

  private
    # Makes a pdf, returns it as data...
    def make_pdf(template_path, pdf_name, landscape=false)
      prince = Prince.new()
      # Sets style sheets on PDF renderer.
      prince.add_style_sheets(
        "#{RAILS_ROOT}/public/stylesheets/touch.css"
      )
      prince.add_style_sheets("#{RAILS_ROOT}/public/stylesheets/prince_landscape.css") if landscape
      # Render the estimate to a big html string.
      # Set RAILS_ASSET_ID to blank string or rails appends some time after
      # to prevent file caching, fucking up local - disk requests.
      ENV["RAILS_ASSET_ID"] = ''
      html_string = render_to_string(:template => template_path, :layout => false)
      # Make all paths relative, on disk paths...
      html_string.gsub!("src=\"", "src=\"#{RAILS_ROOT}/public")
      # Send the generated PDF file from our html string.
      return prince.pdf_from_string(html_string)
    end
  
    # Makes and sends a pdf to the browser
    #
    def make_and_send_pdf(template_path, pdf_name, landscape=true)
      send_data(
        make_pdf(template_path, pdf_name, landscape),
        :filename => pdf_name,
        :type => 'application/pdf'
      ) 
    end
end
