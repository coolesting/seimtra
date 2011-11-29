#set the specifying template for admin view
before '/admin*' do
	set :slim, :layout => :admin_layout
end
