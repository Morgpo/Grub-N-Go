# DEV README
## Schema Changes:
### Add Account Status to Accounts table
- Just kidding, this is already done

### Add Location
- Just kidding, this is already done

### Add Contact
- Just kidding, this is already done

### Add Payment
- Just kidding, this is already done

### Clean up SQL schema to remove duplicate/unused tables
- Remove old tables that are no longer used. Saw addresses are doing something weird. 5-10 tables needed

### Miniumum 24 values per table
- Need to make more demo data for everything

### New SQL DMP after changes
- Need to export new SQL DMP after making changes


## Backend Changes:
### Maybe none?
- See about if there are any new requirements, but I think everything is already done


## Frontend Changes:
### Payment Page
- See `payment_method_crud.py` for this
### Login/Register Page
- See `account_crud.py` for this
### Account Page (Optional)
- Just show all the info for the account, including contact methods from `customer` or `restaurant` table
- See `account_crud.py` for this