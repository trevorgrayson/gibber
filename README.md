#The Gipper

Using environment variables? Using Docker? 

Sick of not knowing a configuration isn't set, or having your app blow up unexpectedly mid-execution?

Configuration woes?  Leave it to The Gipper! Trust OR Verify!

Try throwing the following Gipper block into application.rb, or your app's boot.

ENV variables will be used by default.  You may pass one or many additional hashes to override values.

Use the `trust` method if you would like to throw a warning message in the log.

Use the `verify` method if you would like to throw an error message in the log, and raise an error.

```ruby
ENV['env_var'] = "OK!"

config = {
  a: "some variable",
  b: "some other variable",
  c: 1234,
  d: "peter",
  e: "thorton"
}

GIP = Gipper.review config, ENV do
  trust :e 
  verify :a, :b, :c, :d
  verify :env_var
end

GIP[:a] 
=> "some variable"

GIP["env_var"] 
=> "OK!"

```

Using Services? The Gipper can check if it's running on the port you expect it to be.

```ruby
GIP = Gipper.review config, ENV do
  if Rails.env.production? 
    #will simply throw an error if in production
    verify_service :DATABASE_URL 
  else
    #will try to stand up the service using docker if not in production!
    verify_service :DATABASE_URL do
      Thread.start do
        system 'docker', 'run', 'postgres'
      end
    end
  end
end

```

You may change the logger that Gipper uses by setting the logger.

```ruby
Gipper.logger = Logger.new(STDOUT)
```
