import bcrypt

password = "Reviewer@123"
hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

print(f"Password: {password}")
print(f"Hash: {hashed}")
print()
print("Run this SQL in pgAdmin:")
print()
sql = f"""UPDATE users
SET password_hash = '{hashed}',
    role = 'reviewer'
WHERE email = 'HH@hh.com';"""
print(sql)
