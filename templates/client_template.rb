#
# Generates a basic skeleton app I use for client projects.
#

# Path to the shared source files/templates.
source_path = File.join(File.dirname(__FILE__), 'source')

# Fix a problem with bundler not finding Gemfile when Dir.pwd doesn't return
# the path the app is located in.
ENV['BUNDLE_GEMFILE'] = File.join(destination_root, 'Gemfile')

#
# Ask all the questions we want to know first.
#
use_html5 = yes? 'Use HTML5?'
use_css_960 = yes? 'Use 960 grid CSS?'
# Don't bother asking about reset if we're using 960, as we use it anyhow.
use_css_reset = yes? 'Use CSS reset?' unless use_css_960
use_admin = yes? 'Admin interface (CMS style)?'


#
# Generate main project.
#
project :test => :shoulda, :renderer => :haml, :script => :jquery, :orm => :datamapper

#
# Create a set of common routes used for most clients.
#
app_init = %Q{
  get '/' do
    render 'home'
  end

  get '/contact' do
    render 'contact'
  end

  get '/about' do
    render 'about'
  end
}
inject_into_file 'app/app.rb', app_init, :before => /^end$/
create_file 'app/views/home.haml', '%h1 Homepage'
create_file 'app/views/contact.haml', '%h1 Contact'
create_file 'app/views/about.haml', '%h1 About'

#
# Create main layout/css/javascript based on options.
#
stylesheets, javascripts, haml_attributes, html_attributes = [], [], [], []

# If we're using the reset CSS, make sure it's added first.
if use_css_reset || use_css_960
  copy_file File.join(source_path, 'stylesheets', 'reset.css'), 'public/stylesheets/reset.css'
  stylesheets << "'reset'"
end

if use_css_960
  copy_file File.join(source_path, 'stylesheets', '960.css'), 'public/stylesheets/960.css'
  stylesheets << "'960'"
end


haml_attributes << ':format => :html5' if use_html5
html_attributes << ":xmlns => 'http://www.w3.org/1999/xhtml'" unless use_html5


# Clean up the variables and join them ready for their correct placement.
html_attributes = "{ #{html_attributes.join(', ')} }" unless html_attributes.blank?

# For haml always set :attr_wrapper to ", as I personally perfer this.
haml_attributes << ":attr_wrapper => '\"'"
haml_attributes = haml_attributes.join(', ')

# Add default stylesheets and JS
stylesheets << "'master'"
javascripts << "'jquery'" << "'application'"

layout_init = %Q{!!!doctype
%html#{html_attributes}
  %head
    %title #{fetch_app_name}
    =stylesheet_link_tag #{stylesheets.join(', ')}
    =javascript_include_tag #{javascripts.join(', ')}
  %body
    =yield
}
# Note the space so it's spaced correctly in app/app.rb.
haml_init = %Q{  set :haml, { #{haml_attributes} }\n}

inject_into_file 'app/app.rb', haml_init, :before => "  # set :raise_errors, true"
create_file 'app/views/layouts/application.haml', layout_init
create_file 'public/stylesheets/master.css', '/* Add styles! */'

#
# Create the Admin interface; I don't like decrypt-able passwords so I replace
# the account model for padrino.
#
if use_admin
  generate :admin
  copy_file File.join(source_path, 'models', 'account_dm.rb'), 'app/models/account.rb', :force => true
end