from agno.agent.agent import Agent
from dotenv import load_dotenv
load_dotenv()
from lib.model import model
import yaml
from box import box_from_file
import os
from lib import  get_db

db=get_db()

def create_basic_agents(file_name,
            enable_user_memories=True,
            add_session_state_to_context=True,  # Required so the agent is aware of the session state
            enable_agentic_state=True,  # Adds a tool to manage the session state
            markdown=True,
            debug_mode=True):
    # with open(file_name, "r") as f:
    #     agent_data = yaml.safe_load(f.read())
    instruction_path=f"{os.path.dirname(__file__)}/../instructions"
    agent_data=box_from_file(f"{instruction_path}/{file_name}")

    agents={}

    for name,agent_info in agent_data.items():
        agent_id = name.strip().lower().replace(" ","-")
        if not agent_id:
            continue
        agent_description = agent_info.get('persona')+"\n\n\nyou goal is:\n"+agent_info.get('goals', "")
        expected_output=agent_data.get("expected_output" , None)

        inst_path = f"{instruction_path}/{agent_info.get('instructions', None)}"

        with open(inst_path, "r") as f:
            agent_instructions = f.read()

        agents[agent_id] = Agent(
            name=name,
            db=db,
            model=model,
            description=agent_description,  
            instructions=agent_instructions,
            expected_output=expected_output,
            enable_user_memories=enable_user_memories,
            add_session_state_to_context=add_session_state_to_context,
            enable_agentic_state=enable_agentic_state,
            markdown=markdown,
            debug_mode=debug_mode
        )

    return agents