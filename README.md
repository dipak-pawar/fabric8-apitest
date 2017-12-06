# Introduction

The goal of this project is to test the REST-APIs for the following services
using a comparable approach.

* https://github.com/fabric8-services/fabric8-wit
* https://github.com/fabric8-services/fabric8-auth
* https://github.com/fabric8-services/fabric8-tenant
* https://github.com/fabric8-services/fabric8-notification

The approach is to take the REST definition of each service and generate a Go
client library from it. The REST definition is written with
[GOA](https://goa.design/) in Go and can be converted to proper structures with
functions to call for each resource and action.

## Why use a generated client library?

Suppose, you want to test the use case of listing all open work items in a
space.

The proper URL to call would be this one:

```sh
https://api.openshift.io/api/spaces/020f756e-b51a-4b43-b113-45cec16b9ce9/workitems?filter%5Bworkitemstate%5D=open
```

But how do you know what actions exist on what endpoint? You could go
[here](http://swagger.goa.design/?url=fabric8-services/fabric8-wit/design) to
inspect the swagger definition of any of the above services but that can be very
cumbersome and error prone.

It is much easier and safer to call a function on a client object for the
service under test. That has proper argument types and return types that you can
inspect much easier than some blob. The client then converts the function call
behind the scenes into the proper HTTP command an executes it.


## 1. Prepare

```sh
git clone github.com/kwk/fabric8-apitest
cd fabric8-apitest
make docker-start
make docker-deps
make docker-generate
```

## 2. Run tests

```sh
# Currently there's only one test which doesn't require authentication, so you can just run it
make docker-test
```
## 3. Add more tests

Edit the file `work_item_test.go` to add more tests and run the tests again using `make docker-test`.