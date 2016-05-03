# (C) Copyright Open Permissions Platform Coalition 2015
.PHONY: clean requirements test pylint docs behave_api behave_system behave

# You should not set these variables from the command line.
# Directory that this Makfile is in
SERVICEDIR        = $(shell pwd)

# Directory containing the source code
SOURCE_DIR        = tests

# Directory to output the test reports
TEST_REPORTS_DIR  = tests/reports

# You can set these variables from the command line.
# Directory to build docs in
BUILDDIR          = $(SERVICEDIR)/_build

# Directory to output markdown converted docs to
SERVICE_DOC_DIR   = $(BUILDDIR)/service/html

# Create list of target .html file names to be created based on all .md files found in the 'doc directory'
md_docs :=  $(SERVICE_DOC_DIR)/README.html

clean:
	rm -fr $(TEST_REPORTS_DIR)

# Install requirements
requirements:
	pip install -r $(SERVICEDIR)/requirements.txt
	bundle install

# Run pylint
pylint:
	mkdir -p $(TEST_REPORTS_DIR)
	@pylint $(SOURCE_DIR)/ --output-format=html > $(TEST_REPORTS_DIR)/pylint-report.html || {\
	 	echo "\npylint found some problems."\
		echo "Please refer to the report: $(TEST_REPORTS_DIR)/pylint-report.html\n";\
	 }

# Dependency of .html document files created from README.md
$(SERVICE_DOC_DIR)/README.html : $(SERVICEDIR)/README.md
	mkdir -p $(dir $@)
	grip $< --export $@

# Create .html docs from all markdown files
md_docs: $(md_docs)

# Create all docs
docs: md_docs

behave_api:
	cd tests && \
	(behave api --randomize --junit --junit-directory reports --tags ~@notimplemented -k -o reports/api_results.txt) || (exit 0)

behave_system:
	cd tests && \
	(behave system --randomize --junit --junit-directory reports --tags ~@notimplemented -k -o reports/system_results.txt) || (exit 0)

behave:
	cd tests && \
	(behave . --randomize --junit --junit-directory reports --tags ~@notimplemented -k -o reports/all_results.txt) || (exit 0)
