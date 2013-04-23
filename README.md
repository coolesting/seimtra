# What is the Seimtra ?

Seimtra is a web application system(**WAS**) that supplies a platform to user how easy to setup a website and to developer how fast to create an application with module.

Seimtra consists of the famous applications **sinatra**, **sequel**, **slim** (So, the alias name called **3s**) as the core framework, and thousands of modules which extends the web application is created.



# How to install the Seimtra ?

Installing dependon gem at first

	gem install sequel
	gem install thor

	git clone git://github.com/sinatra/sinatra.git sinatra

	git clone git://github.com/slim-template/slim slim
	git checkout 845a899ffd785d63180adb85491bc178a7e057a2

	git clone git://github.com/coolesting/seimtra.git seimtra

	cd gem_dir
	gem build gem_name.gemspec
	gem install gem_name.x.x.x --local



# How to deploy a web project with Seimtra ?

	3s init myproject

or

	3s new myproject

start the web application myproject

	cd myproject
	thin start

check the information about the project

	3s info

see the module information

	3s info system

see the Seimtra version

	3s version

list the modules

	3s list

> Note : Whatever you want to do something to the project, make sure your location is under the root directory of that projec.



# How to extend your web application ?

add a module called post

	3s add post

or

	3s install post

install all of modules that have not been installed yet


# How to create a module ?

some structure direstoris is required as you see when you type this command to create a module folders tree.

	3s create my_module

create a scaffold to your module

	3s g post title body --to=my_module


# How to deal with the database ?

see the database schema

	3s db -o
	3s db -od

create a migration record
	

	3s db article title body

or

	3s db article title body -a

The option *-a* will automatic adds the key *primary id*, *changed time*, and *created time*.

run the migration record

	3s db -r

Any database operations based on Sequel ORM, for more details see the [Sequel Docs](http://sequel.rubyforge.org/documentation.html).
