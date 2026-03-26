import random
from faker import Faker
from datetime import timedelta

# Initialize Faker
fake = Faker()

# Configuration
NUM_ROWS = 100
OUTPUT_FILE = "insert_data_from_script_python.sql"

def generate_data():
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write("-- =====================================================\n")
        f.write("-- AUTO-GENERATED INSERT STATEMENTS (100 ROWS PER TABLE)\n")
        f.write("-- =====================================================\n\n")
        f.write("BEGIN;\n\n")

        # --- 1. AIRPORT DATA ---
        f.write("-- Table: AIRPORT\n")
        airport_ids = list(range(1, NUM_ROWS + 1))
        used_iata = set()
        
        for i in airport_ids:
            name = f"{fake.city()} International Airport".replace("'", "''")
            city = fake.city().replace("'", "''")
            region = fake.state().replace("'", "''")
            country = fake.country().replace("'", "''")
            
            # Ensure unique 3-letter IATA code
            iata = fake.unique.lexify(text='???').upper()
            timezone = f"UTC{random.choice(['+','-'])}{random.randint(1,12)}"
            
            f.write(f"INSERT INTO AIRPORT (name, city, region, country, iata_code, timezone) "
                    f"VALUES ('{name}', '{city}', '{region}', '{country}', '{iata}', '{timezone}');\n")

        # --- 2. ROUTE DATA ---
        f.write("\n-- Table: ROUTE\n")
        route_ids = list(range(1, NUM_ROWS + 1))
        for i in route_ids:
            # Randomly select two different airports
            origin = random.choice(airport_ids)
            dest = random.choice([x for x in airport_ids if x != origin])
            f.write(f"INSERT INTO ROUTE (origin_airport_id, destination_airport_id) "
                    f"VALUES ({origin}, {dest});\n")

        # --- 3. AIRCRAFT DATA ---
        f.write("\n-- Table: AIRCRAFT\n")
        aircraft_brands = {
            "Boeing": ["737", "747", "777", "787"],
            "Airbus": ["A320", "A330", "A350", "A380"],
            "Embraer": ["E190", "E195"]
        }
        aircraft_ids = list(range(1, NUM_ROWS + 1))
        for i in aircraft_ids:
            brand = random.choice(list(aircraft_brands.keys()))
            model = random.choice(aircraft_brands[brand])
            capacity = random.randint(80, 450)
            status = random.choice(['Active', 'Maintenance', 'Active'])
            f.write(f"INSERT INTO AIRCRAFT (model, manufacturer, capacity, status) "
                    f"VALUES ('{model}', '{brand}', {capacity}, '{status}');\n")

        # --- 4. FLIGHT DATA ---
        f.write("\n-- Table: FLIGHT\n")
        for i in range(1, NUM_ROWS + 1):
            flight_no = f"{fake.bothify(text='??-####').upper()}"
            dep_time = fake.date_time_this_year(before_now=False, after_now=True)
            # Ensure arrival is 1 to 12 hours after departure
            arr_time = dep_time + timedelta(hours=random.randint(1, 12))
            status = random.choice(['Scheduled', 'On Time', 'Delayed'])
            route = random.choice(route_ids)
            aircraft = random.choice(aircraft_ids)
            
            f.write(f"INSERT INTO FLIGHT (flight_number, departure_time, arrival_time, status, route_id, aircraft_id) "
                    f"VALUES ('{flight_no}', '{dep_time}', '{arr_time}', '{status}', {route}, {aircraft});\n")

        # --- 5. TERMINAL DATA ---
        f.write("\n-- Table: TERMINAL\n")
        terminal_ids = list(range(1, NUM_ROWS + 1))
        for i in terminal_ids:
            t_name = f"Terminal {random.choice(['Alpha', 'Bravo', 'C', 'North', 'South'])}"
            t_num = str(random.randint(1, 6))
            cap = random.randint(2000, 15000)
            air_id = random.choice(airport_ids)
            f.write(f"INSERT INTO TERMINAL (terminal_name, terminal_number, capacity, airport_id) "
                    f"VALUES ('{t_name}', '{t_num}', {cap}, {air_id});\n")

        # --- 6. GATE DATA ---
        f.write("\n-- Table: GATE\n")
        for i in range(1, NUM_ROWS + 1):
            g_num = f"{random.choice(['A','B','G'])}{random.randint(1, 40)}"
            g_status = random.choice(['Open', 'Closed', 'Under Cleaning'])
            max_p = random.randint(100, 350)
            term_id = random.choice(terminal_ids)
            f.write(f"INSERT INTO GATE (gate_number, status, max_passengers, terminal_id) "
                    f"VALUES ('{g_num}', '{g_status}', {max_p}, {term_id});\n")

        f.write("\nCOMMIT;")
    
    print(f"File '{OUTPUT_FILE}' created successfully with {NUM_ROWS * 6} lines.")

if __name__ == "__main__":
    generate_data()