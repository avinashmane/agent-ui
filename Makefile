APP_ROOT=/home/avinash/solai
VENV=. .venv/bin/activate &
TEST_ENV=.env#.test
VENV_TEST=$(VENV) dotenv -f $(TEST_ENV) run

# Frontend/Client
chat:
	# streamlit
	$(VENV) streamlit run app/Agent_Sol.py --server.headless true

# backend/Server
server:
	$(VENV) uv run uvicorn main_agentos:app --port 7777 --reload

my_os: #test server
	uv run uvicorn scratch.my_os:app

rag-test:
	echo 'Testing with $(TEST_ENV)'
	$(VENV_TEST) uv run test/rag_agent.py 


pgvector:  # requires docker
	docker start pgvector || make pgvector-docker
pgvector-stop:
	docker stop pgvector
pgvector-docker:
	docker run -d \
	-e POSTGRES_DB=ai \
	-e POSTGRES_USER=ai \
	-e POSTGRES_PASSWORD=ai \
	-e PGDATA=/var/lib/postgresql/data/pgdata \
	-v pgvolume:/var/lib/postgresql/data \
	-p 5532:5432 \
	--name pgvector \
	agnohq/pgvector:16

ollama:
	docker start ollama || make ollama-docker
ollama-docker:  # requires docker
	docker run -d --rm --name ollama -p 11434:11434 -v /home/avinash/ollama:/var/lib/ollama ollama/ollama:latest
ollama-stop:
	docker stop ollama

prep:
	source .env/bin/pip

mcp-csv:
	$(VENV) uv run mcp/csv/mcp-csv.py

mcp_gen-srv:
	$(VENV) uv run mcp_gen/server.py

mcp_gen-cli:
	$(VENV) uv run mcp_gen/client.py

mcp_gen: mcp_gen-srv mcp_gen-cli
