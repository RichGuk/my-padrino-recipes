#
# Add the padrino admin interface to an existing project, but replace the
# accounts model with one that doesn't have decrypt-able passwords.
#

# Path to the shared source files/templates.
source_path = File.join(File.dirname(__FILE__), '..', 'files') unless source_path

generate :admin
copy_file File.join(source_path, 'models', 'account_dm.rb'), destination_root('app/models/account.rb'), :force => true