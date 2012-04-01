# INTRDDUCTION

Seimtra is a web application system that creates an application structure with sinatra, sequel, slim. And it still integrates generated function as the ROR.


# INSTALLATION

	gem install seimtra
or
	git clone git://github.com/coolesting/seimtra.git

# USAGE


### Step 01, Creating a project

	3s new myproject

So, we start to set the root routor in environment.rb. 
By default, the public/index.html will be realized the default page. 
You could uncomment the last three lines in envrionment, and remove the public/index.html.

Check the info of the project

	3s info

> Note : Whatever you want to do something to this project, please enter to the root directory of your project, then using your command line to it.


### Step 02, Creating a module

This is modular structure application that consist of some variety of modules.
It divides all function into each module. So, whatever we want to do something, we need to
create a new module in order to collect the same application.

For example, we need a menber administration in the new project, so we do this.

	3s m new users

we create a module called __users__,  then check the info about this module.

	3s m info

or

	3s m info users

> Note : the __3s__ will set the default module by new module name to config file after you create a new module. we can see the config item __module_focus__ after command __3s info__

And we could set the module info with,

	3s m info email:myemail@example.com author:yourname

See the module how many is in current project,

	3s m list


### Step 03, about the database

We will not teach you how to create a database, but the connected approach about the mysql, postgresql, sqlite that be wrote to file environment.rb.
More details please see the document of [Sequel](http://sequel.rubyforge.org/documentation.html).

Now, we reseach the __3s db__ command.
See the db info

	3s db -o
	3s db -o --details

Create a migration record.

	3s db create users String:username String:password String:salt -a

the option __-a__ will auto adds the __primary id__, __changed time__, and __created time__.
You could alter this migration file before running to the database.

	3s db -r

> Note : anything about the migration record please see the sequel.
