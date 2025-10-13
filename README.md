# Grub-N-Go

## How to Run Locally (Development and Production)
1. Clone the repository
2. Start MySQL server
    a. Create a database named `GrubnGo`
       i. Doesn't have to be `GrubnGo`, but make sure to update the `.env` file in `Backend/` folder accordingly
    b. Run the SQL scripts in `Database/` folder to set up schema and seed data
3. Start the backend server
    a. Make sure Python is installed
    b. Navigate to `Backend/` folder
    c. Create a `.env` file based on the `.env.example` file
    d. Run `setup/setup_venv.py` to set up a python virtual environment and install dependencies
    e. Activate the virtual environment
       i. On Windows: `.\venv\Scripts\activate`
       ii. On Mac/Linux: `source venv/bin/activate`
    f. Run `python main.py` to start the server
4. Start the frontend server
    a. Make sure Node.js is installed
    b. Navigate to `Frontend/` folder in a new terminal
    c. Run `npm install` to install dependencies
        i. Run `npm run build` to start the frontend server (Production)
        ii. Run `npm run dev` to start the frontend server (Development)