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
