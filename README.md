# What is the Seimtra ?

Seimtra is a web application system(**WAS**) that supplies a platform to user how easy to setup a website and to developer how fast to create an application with module.

Seimtra consists of the famous applications **sinatra**, **sequel**, **slim** (So, the alias name called **3s**) as the core framework, and thousands of modules which extends the web application is created.



# How to install the Seimtra ?

copy a instance of seimtra, and run it

	git clone git://github.com/coolesting/seimtra-docs.git myapp
	bundle install --gemfile=myapp/modules/system/Gemfile



# Create an application instance by seimtra

	3s init myapp



# How to deploy a web project with Seimtra ?

	cd myapp
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

fetch the module from git repository to local

	3s fetch cms

install the module

	3s install cms



# How to create a module ?

some structure direstoris is required as you see when you type this command to create a module folders tree.

	3s new my_module

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
