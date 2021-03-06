## More About Kudu

To see a list of kudu build tasks use the below

```
kudu -h
```

For details on the options for a particular command

```
kudu -h [Task]
```
## Transitive Dependencies - kudu.yaml

kudu manages transitive dependencies between modules through the kudu.yaml file at each projects root.  This structure should look familiar for anyone who has worked with Apache Ivy.  Note in-house dependencies are not versioned - it is implicit that you want the "latest" version. Third party dependencies can be optionally versioned with a Rational Versioning Policy (RVP) string.  If absent "latest" is assumed.  kudu's format for specifying transitive dependencies is not as general as Ivy but works well for organizing source modules is a single git repository.

```
---
:project
  :name: kudu_example_api
  :type: sinatra                          # [sinatra|gem] - more project types soon
:publications:
 - :name: kudu_example_api
   :version: 0.0.1                        # version (RVP)    [required]
   :group: in-house                       # group - in-house or third-party
   :type: gem                             # [gem] - more publication types soon
:dependencies:  
  :name: kudu_util
  :group: in-house                
- :name: mongo
  :group: third-party
  :version: '>=1.8'                     # version          [optional]
- :name: json                           # implicitly version to 'latest'
  :group: third-party  
```

## Optimized Developer Iterations

If the build command is invoked with the -o option kudu will do what it can to improve the efficiency developer iterations.  In the case of ruby based projects this implies that kudu will replace the files in the installed gems with links back to the source tree. In conjunction with shotgun this implies that you can build a web service its dependencies once and then edit source in-situ and simply refresh the browser or re-issue the API call.  To see how this works see the odi sample projects.

```
> vagrant ssh # from the guest OS 
> cd kudu/example/odi/kudu_odi_api
> kudu build -d -o # build with dependencies using the --odi option
> kudu service-start
```

Now if you edit the dependency *example/odi/kudu_odi_gem/lib/kudu_odi_gem.rb* you will see the modifications show upon a browser refresh.  No further building is necssary when working in this mode.

## Project generation

Currently kudu can generate skeleton modules for two types of projects, a vanilla ruby gem and trivial sinatra webapp. 

```
	kudu -h create-project
```





















































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































