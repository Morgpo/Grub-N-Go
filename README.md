# Grub-N-Go

## How to Run Locally (Development and Production)
### 1. Clone the repository
### 2. Start MySQL server
### 3. Create a database named `GrubnGo`
- Doesn't have to be `GrubnGo`, but make sure to update the `.env` file in `Backend/` folder accordingly
- Run the SQL scripts in `Database/` folder to set up schema and seed data
### 4. Start the backend server
- Make sure Python is installed
- Navigate to `Backend/` folder
- Create a `.env` file based on the `.env.example` file
- Run `setup/setup_venv.py` to set up a python virtual environment and install dependencies
- Activate the virtual environment
	- On Windows: `.\venv\Scripts\activate`
	- On Mac/Linux: `source venv/bin/activate`
- Run `python main.py` to start the server
### 5. Start the frontend server
- Make sure Node.js is installed
- Navigate to `Frontend/` folder in a new terminal
- Run `npm install` to install dependencies
	- Run `npm run build` to start the frontend server (Production)
	- Run `npm run dev` to start the frontend server (Development)
