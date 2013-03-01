## Kudu Examples

To generate a sample gem

```
> kudu create-project -n kudu_example_gem 
```

To generate a sample sinatra service 

```
> kudu create-project -n kudu_example_sinatra  -t sinatra
```

To generate a sample sinatra service that depends upon kudu_test_gem

```
> kudu create-project -n kudu_example_sinatra_dep -t sinatra -d '{namespace:%q{kudu}, group:%q{in-house}, name:%q{kudu_example_gem}, type:%q{gem}}'
```

Build the sinatra API with dependencies

```
> cd kudu_test_sinatra
> kudu build -d
```
