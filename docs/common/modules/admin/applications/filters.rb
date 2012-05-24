before '/admin*' do
	@title = "Administration console"

	mid = DB[:menus][:name => 'admin'][:mid]
	@links_admin = DB[:links].filter(:mid => mid).order(:order)
end
