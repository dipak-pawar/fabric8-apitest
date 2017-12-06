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