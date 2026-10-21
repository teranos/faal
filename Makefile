.PHONY: build install clean test

PREFIX ?= $(HOME)/.qntx
DC ?= ldc2
DUB ?= dub

# Restart — POST /api/plugins/faal/restart (ADR-002) to the node on BACKEND_PORT, default 8772.
# Silent no-op when no node answers there.
define restart-plugin
	@PORT=$${BACKEND_PORT:-8772}; \
	 curl -sf -X POST http://127.0.0.1:$$PORT/api/plugins/faal/restart > /dev/null 2>&1 \
		&& echo "  ↻ LOADED — faal restarted, live at http://127.0.0.1:$$PORT" \
		|| echo "  ⊘ NOT LOADED — no QNTX node answers on 127.0.0.1:$$PORT, binary is built but not active"
endef

build: ## Build faal plugin binary
	@echo "Building qntx-faal-plugin (D/LDC)..."
	@$(DUB) build --compiler=$(DC) --config=application
	@echo "✓ bin/qntx-faal-plugin"

test: ## Run D unit tests
	@echo "Running faal unit tests..."
	@$(DUB) test --compiler=$(DC)
	@echo "✓ faal tests passed"

install: build ## Install faal plugin to ~/.qntx/plugins/ and restart
	@echo "Installing qntx-faal-plugin to $(PREFIX)/plugins..."
	@mkdir -p $(PREFIX)/plugins
	@cp bin/qntx-faal-plugin $(PREFIX)/plugins/qntx-faal-plugin
	@chmod +x $(PREFIX)/plugins/qntx-faal-plugin
	@echo "✓ qntx-faal-plugin → $(PREFIX)/plugins/qntx-faal-plugin"
	$(call restart-plugin)

clean: ## Clean build artifacts
	@rm -rf bin/ .dub/
