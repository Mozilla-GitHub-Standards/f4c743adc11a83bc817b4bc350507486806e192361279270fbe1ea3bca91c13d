APPNAME = appsync
DEPS = 
VIRTUALENV = virtualenv
PYTHON = bin/python
NOSE = bin/nosetests -s --with-xunit
FLAKE8 = bin/flake8
COVEROPTS = --cover-html --cover-html-dir=html --with-coverage --cover-package=appsync
TESTS = appsync
PKGS = appsync
COVERAGE = bin/coverage
PYLINT = bin/pylint
SERVER = dev-auth.services.mozilla.com
SCHEME = https
PYPI = http://c.pypi.python.org/simple
PYPI2RPM = bin/pypi2rpm.py --index=$(PYPI)
PYPIOPTIONS = -i $(PYPI)
CHANNEL = dev
RPM_CHANNEL = prod
PIP_CACHE = /tmp/pip-cache
INSTALL = bin/pip install --download-cache=$(PIP_CACHE)
BUILDAPP = bin/buildapp --download-cache=$(PIP_CACHE)
BUILDRPMS = bin/buildrpms --download-cache=$(PIP_CACHE)
INSTALLOPTIONS = -U -i $(PYPI)
TIMEOUT = 300
DURATION = 30
CYCLES = 5:10:20
HOST = http://localhost:5000

ifdef PYPIEXTRAS
	PYPIOPTIONS += -e $(PYPIEXTRAS)
	INSTALLOPTIONS += -f $(PYPIEXTRAS)
endif

ifdef PYPISTRICT
	PYPIOPTIONS += -s
	ifdef PYPIEXTRAS
		HOST = `python -c "import urlparse; print urlparse.urlparse('$(PYPI)')[1] + ',' + urlparse.urlparse('$(PYPIEXTRAS)')[1]"`

	else
		HOST = `python -c "import urlparse; print urlparse.urlparse('$(PYPI)')[1]"`
	endif

endif

INSTALL += $(INSTALLOPTIONS)

.PHONY: all build build_rpms test update

all:	build

build_mcrypto:
	cd /tmp; wget http://ziade.org/M2Crypto-0.21.1.linux-x86_64.tar.gz
	$(INSTALL) /tmp/M2Crypto-0.21.1.linux-x86_64.tar.gz
	rm /tmp/M2Crypto-0.21.1.linux-x86_64.tar.gz

build:
	$(VIRTUALENV) --no-site-packages --distribute .
	$(INSTALL) MoPyTools
	$(INSTALL) nose
	$(INSTALL) WebTest
	$(INSTALL) wsgi_intercept
	$(BUILDAPP) -t $(TIMEOUT) -c $(CHANNEL) $(PYPIOPTIONS) $(DEPS)

update:
	$(BUILDAPP) -t $(TIMEOUT) -c $(CHANNEL) $(PYPIOPTIONS) $(DEPS)

test:
	$(NOSE) $(TESTS)

build_rpms:
	$(BUILDRPMS) -t $(TIMEOUT) -c $(RPM_CHANNEL) $(DEPS)

mach: build build_rpms
	mach clean
	mach yum install python26 python26-setuptools
	cd rpms; wget http://mrepo.mozilla.org/mrepo/5-x86_64/RPMS.mozilla-services/gunicorn-0.11.2-1moz.x86_64.rpm
	cd rpms; wget http://mrepo.mozilla.org/mrepo/5-x86_64/RPMS.mozilla/nginx-0.7.65-4.x86_64.rpm
	mach yum install rpms/*
	mach chroot python2.6 -m appsync.run

clean:
	rm -rf bin lib include local docs/build

loadonce:
	cd loadtest; ../bin/fl-run-test -u $(HOST) simple.py

load:
	cd loadtest; ../bin/fl-run-bench -u $(HOST) -c $(CYCLES) -D $(DURATION) simple.py SimpleTest.test_something

