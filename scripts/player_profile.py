import psycopg2
from pathlib import Path

SQL_PATH = Path(__file__).resolve().parent.parent / "sql" / "queries" / "player_profile.sql"
profile_sql = SQL_PATH.read_text()

LOOKUP_SQL = "SELECT player_key, player_name FROM dim_player WHERE player_name ILIKE %s"


def resolve_player(cur, search_term):
    """Return the chosen player's key, or None if not found."""
    last_name = search_term.split()[-1]
    cur.execute(LOOKUP_SQL, ('%' + last_name + '%',))
    rows = cur.fetchall()

    if not rows:
        print(f"No player found named: {search_term}")
        return None

    if len(rows) == 1:
        return rows[0][0]

    while True:
        for i, row in enumerate(rows):
            print(f"{i + 1}) {row[1]}")
        try:
            choice = int(input("Select the row number for player's stats: "))
            if 1 <= choice <= len(rows):
                return rows[choice - 1][0]
        except ValueError:
            pass
        print("Please choose a valid option")


def print_profile(profile):
    labels = [
        ("Innings played", 1), ("Total runs", 2), ("Highest score", 3),
        ("Batting average", 4), ("Strike rate", 5), ("Fours", 6),
        ("Sixes", 7), ("Dismissals", 8),
    ]
    print(f"\n===== {profile[0]} — IPL Career =====")
    for label, idx in labels:
        print(f"{label:<15}: {profile[idx]}")
    print()


def main():
    search_term = input("Enter the player name: ").strip()
    if not search_term:
        print("Please enter a player name.")
        return

    conn = psycopg2.connect(dbname="ipl", user="smitsanghvi", host="localhost", port=5432)
    try:
        with conn.cursor() as cur:
            key = resolve_player(cur, search_term)
            if key is None:
                return
            cur.execute(profile_sql, (key, key, key))
            print_profile(cur.fetchone())
    finally:
        conn.close()

if __name__ == "__main__":
    main()