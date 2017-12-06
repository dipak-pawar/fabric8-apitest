# 0. Install tools (tested on Fedora)

```sh
sudo dnf install -y make golang git mercurial
```

# 1. Get the code

```sh
# Make sure you have GOPATH set and all directories exist
export GOPATH=~/go
mkdir -p $GOPATH/src
mkdir -p $GOPATH/pkg
mkdir -p $GOPATH/bin
# Clone this repo and put it in the right directory
git clone github.com/kwk/fabric8-apitest $GOPATH/src/github.com/fabric8-services/fabric8-apitest
sudo 
```

# 2. Prepare

```sh
# Installs the GO package management tool "glide" to $GOPATH/bin
make prereq

# Download all dependencies into the vendor directory
make deps

# Generate the client libraries for the various services to test
make generate
```

# 3. Run tests

```sh
# Currently there's only one test which doesn't require authentication, so you can just run it
make test
```
# 4. Add more tests

Edit the file `work_item_test.go` and run the tests again using `make test`.