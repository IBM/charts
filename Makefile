###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2017. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
include Configfile

.DEFAULT: charts-stable

$(STABLE_BUILD_DIR):
	@mkdir -p $@

$(INCUBATING_BUILD_DIR):
	@mkdir -p $@

$(REFERENCE_BUILD_DIR):
	@mkdir -p $@

.PHONY: charts charts-stable charts-incubating charts-reference $(STABLE_CHARTS) $(INCUBATING_CHARTS) $(REFERENCE_CHARTS)

# Default aliases: charts, repo

charts: charts-stable

repo: repo-stable

charts-stable: $(STABLE_CHARTS)
$(STABLE_CHARTS): $(STABLE_BUILD_DIR) 
	helm lint --strict $@
	helm package $@ -d $(STABLE_BUILD_DIR)

charts-incubating: $(INCUBATING_CHARTS)
$(INCUBATING_CHARTS): $(INCUBATING_BUILD_DIR) 
	helm lint --strict $@
	helm package $@ -d $(INCUBATING_BUILD_DIR)

charts-reference: $(REFERENCE_CHARTS)
$(REFERENCE_CHARTS): $(REFERENCE_BUILD_DIR) 
	helm lint --strict $@
	helm package $@ -d $(REFERENCE_BUILD_DIR)

.PHONY: repo repo-stable repo-incubating repo-reference

repo-stable: $(STABLE_CHARTS) $(STABLE_BUILD_DIR)
	helm repo index $(STABLE_BUILD_DIR) --url $(STABLE_REPO_URL)

repo-incubating: $(INCUBATING_CHARTS) $(INCUBATING_BUILD_DIR)
	helm repo index $(INCUBATING_BUILD_DIR) --url $(INCUBATING_REPO_URL)

repo-reference: $(REFERENCE_CHARTS) $(REFERENCE_BUILD_DIR)
	helm repo index $(REFERENCE_BUILD_DIR) --url $(REFERENCE_REPO_URL)

.PHONY: all
all: repo-stable repo-incubating repo-reference $(STABLE_CHARTS) $(INCUBATING_CHARTS)  $(REFERENCE_CHARTS)

image:: repo-stable repo-incubating repo-reference

include Makefile.docker