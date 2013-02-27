## Kudu Examples

To generate a sample gem

```
> kudu create-project -n kudu_test_gem 
```

To generate a sample sinatra service 

```
> kudu create-project -n kudu_test_sinatra  -t sinatra
```

To generate a sample sinatra service that depends upon kudu_test_gem

```
> kudu create-project -n kudu_test_sinatra_dep -t sinatra -d '{namespace:%q{kudu}, group:%q{in-house}, name:%q{test_gem}}'
```

Build the sinatra API with dependencies

```
> cd kudu_test_sinatra
> kudu build -d
```
