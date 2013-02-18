## Kudu Examples

To generate a sample gem

```
> kudu create-gem -n test_gem -s kudu 
```

To generate a sample sinatra service that depends upon kudu_test_gem

```
> kudu create-gem -n test_sinatra -s kudu -r -d '{namespace:%q{kudu}, group:%q{in-house}, name:%q{test_gem}}'
```

Build the sinatra API with dependencies

```
> cd kudu_test_sinatra
> kudu build -d
```
