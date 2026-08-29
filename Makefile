.PHONY: lint
lint:
	trunk check -a -y

.PHONY: format
format:
	trunk fmt -a

# Validate all agent skills under skills/ (including nested dirs).
.PHONY: validate
validate:
	bash ./scripts/validate_agent_skills.sh

.PHONY: test
test:
	bash ./scripts/test-plugin-manifest.sh
	npm ci --prefix skills/gh-wiki-diagrams/scripts
	bash ./skills/gh-wiki-diagrams/scripts/test-fixtures.sh
	bash ./skills/gh-wiki-diagrams/scripts/test-parse-files.sh
	bash ./skills/gh-knowledge-maintain/scripts/test-evidence.sh
	bash ./skills/gh-wiki-validate/scripts/test-validate-page.sh
	bash ./skills/gh-knowledge-maintain/scripts/test-audit-loop.sh
