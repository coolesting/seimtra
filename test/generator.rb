class Stest

	def g
		system "3s g tag tid:primary_key name --to=system"
	end

	def g_rm
		system "rm modules/system/templates/system_tag.slim"
		system "rm modules/system/templates/system_tag_form.slim"
		system "rm modules/system/applications/tag.rb"
		system "rm modules/system/migrations/005_create_tag.rb"
	end

end
