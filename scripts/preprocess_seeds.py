#!/usr/bin/env python3
"""Emit cleaned CSVs under seeds/ from datasets/northwind extracts (plan §5)."""
from __future__ import annotations

import csv
import hashlib
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "datasets" / "northwind"
OUT = ROOT / "seeds"
MANIFEST = ROOT / "scripts" / "seed_manifest.json"


def sanitize_text(val: str, *, max_len: int = 8000) -> str:
    if val is None:
        return ""
    val = str(val)[:max_len]
    out = []
    for ch in val:
        if ch.isprintable():
            out.append(ch)
        elif ch in "\t\n\r":
            out.append(" ")
        else:
            out.append(" ")
    return re.sub(r"\s+", " ", "".join(out)).strip()


def parse_salary(val: str) -> str:
    """Return numeric string suitable for CSV; empty if unparseable."""
    if not val:
        return ""
    s = sanitize_text(val, max_len=80)
    if len(s) > 24:
        return ""
    m = re.search(r"-?\d+(?:\.\d+)?$", s.strip()) or re.search(r"-?\d+(?:\.\d+)?", s.strip())
    return m.group(0) if m else ""


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def read_csv_dict(path: Path) -> tuple[list[str], list[dict[str, str]]]:
    with path.open(newline="", encoding="utf-8", errors="replace") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
        fields = reader.fieldnames or []
    return fields, rows


def write_csv(path: Path, fieldnames: list[str], rows: list[dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_MINIMAL)
        w.writeheader()
        w.writerows(rows)


def main() -> None:
    patterns = {
        "customers": "Customers_*.csv",
        "customer_demographics": "CustomerDemographics_*.csv",
        "customer_customer_demo": "CustomerCustomerDemo_*.csv",
        "orders": "Orders_*.csv",
        "order_details": "_Order_Details__*.csv",
        "employees": "Employees_*.csv",
        "shippers": "Shippers_*.csv",
    }

    outputs: dict[str, dict[str, object]] = {}

    # --- customers ---
    p = next(SRC.glob(patterns["customers"]))
    _, rows = read_csv_dict(p)
    cust_rows = []
    for r in rows:
        cust_rows.append(
            {
                "customer_id": sanitize_text(r.get("CustomerID", "")),
                "company_name": sanitize_text(r.get("CompanyName", "")),
                "contact_name": sanitize_text(r.get("ContactName", "")),
                "contact_title": sanitize_text(r.get("ContactTitle", "")),
                "address": sanitize_text(r.get("Address", "")),
                "city": sanitize_text(r.get("City", "")),
                "region": sanitize_text(r.get("Region", "")),
                "postal_code": sanitize_text(r.get("PostalCode", "")),
                "country": sanitize_text(r.get("Country", "")),
                "phone": sanitize_text(r.get("Phone", "")),
                "fax": sanitize_text(r.get("Fax", "")),
            }
        )
    fp = OUT / "customers.csv"
    write_csv(
        fp,
        [
            "customer_id",
            "company_name",
            "contact_name",
            "contact_title",
            "address",
            "city",
            "region",
            "postal_code",
            "country",
            "phone",
            "fax",
        ],
        cust_rows,
    )
    outputs["customers.csv"] = {"rows": len(cust_rows), "sha256": sha256_file(fp)}

    # --- customer_demographics ---
    p = next(SRC.glob(patterns["customer_demographics"]))
    _, rows = read_csv_dict(p)
    cd_rows = []
    for r in rows:
        cd_rows.append(
            {
                "customer_type_id": sanitize_text(r.get("CustomerTypeID", "")),
                "customer_desc": sanitize_text(r.get("CustomerDesc", "")),
            }
        )
    fp = OUT / "customer_demographics.csv"
    write_csv(fp, ["customer_type_id", "customer_desc"], cd_rows)
    outputs["customer_demographics.csv"] = {"rows": len(cd_rows), "sha256": sha256_file(fp)}

    # --- customer_customer_demo ---
    p = next(SRC.glob(patterns["customer_customer_demo"]))
    _, rows = read_csv_dict(p)
    ccd_rows = []
    for r in rows:
        ccd_rows.append(
            {
                "customer_id": sanitize_text(r.get("CustomerID", "")),
                "customer_type_id": sanitize_text(r.get("CustomerTypeID", "")),
            }
        )
    fp = OUT / "customer_customer_demo.csv"
    write_csv(fp, ["customer_id", "customer_type_id"], ccd_rows)
    outputs["customer_customer_demo.csv"] = {"rows": len(ccd_rows), "sha256": sha256_file(fp)}

    # --- orders ---
    p = next(SRC.glob(patterns["orders"]))
    _, rows = read_csv_dict(p)
    ord_rows = []
    for r in rows:
        ord_rows.append(
            {
                "order_id": sanitize_text(r.get("OrderID", "")),
                "customer_id": sanitize_text(r.get("CustomerID", "")),
                "employee_id": sanitize_text(r.get("EmployeeID", "")),
                "order_date": sanitize_text(r.get("OrderDate", "")),
                "required_date": sanitize_text(r.get("RequiredDate", "")),
                "shipped_date": sanitize_text(r.get("ShippedDate", "")),
                "ship_via": sanitize_text(r.get("ShipVia", "")),
                "freight": sanitize_text(r.get("Freight", "")),
                "ship_name": sanitize_text(r.get("ShipName", "")),
                "ship_address": sanitize_text(r.get("ShipAddress", "")),
                "ship_city": sanitize_text(r.get("ShipCity", "")),
                "ship_region": sanitize_text(r.get("ShipRegion", "")),
                "ship_postal_code": sanitize_text(r.get("ShipPostalCode", "")),
                "ship_country": sanitize_text(r.get("ShipCountry", "")),
            }
        )
    fp = OUT / "orders.csv"
    write_csv(
        fp,
        [
            "order_id",
            "customer_id",
            "employee_id",
            "order_date",
            "required_date",
            "shipped_date",
            "ship_via",
            "freight",
            "ship_name",
            "ship_address",
            "ship_city",
            "ship_region",
            "ship_postal_code",
            "ship_country",
        ],
        ord_rows,
    )
    outputs["orders.csv"] = {"rows": len(ord_rows), "sha256": sha256_file(fp)}

    # --- order_details ---
    p = next(SRC.glob(patterns["order_details"]))
    _, rows = read_csv_dict(p)
    od_rows = []
    for r in rows:
        od_rows.append(
            {
                "order_id": sanitize_text(r.get("OrderID", "")),
                "product_id": sanitize_text(r.get("ProductID", "")),
                "unit_price": sanitize_text(r.get("UnitPrice", "")),
                "quantity": sanitize_text(r.get("Quantity", "")),
                "discount": sanitize_text(r.get("Discount", "")),
            }
        )
    fp = OUT / "order_details.csv"
    write_csv(fp, ["order_id", "product_id", "unit_price", "quantity", "discount"], od_rows)
    outputs["order_details.csv"] = {"rows": len(od_rows), "sha256": sha256_file(fp)}

    # --- employees (drop Photo; sanitize text; numeric Salary) ---
    # Northwind CSV can explode row width when Photo contains binary; standard DictReader
    # misaligns columns. Rebuild each row: fields 0–13 = EmployeeID…Extension, last four =
    # Notes, ReportsTo, PhotoPath, Salary when the parser returns extra tokens.
    p = next(SRC.glob(patterns["employees"]))
    with p.open(newline="", encoding="utf-8", errors="replace") as f:
        reader = csv.reader(f)
        header = next(reader)
        emp_rows = []
        for row in reader:
            if len(row) <= 14:
                continue
            if len(row) == len(header):
                notes_raw = row[15]
                reports_raw = row[16]
                path_raw = row[17]
                sal_raw = row[18]
            else:
                notes_raw = row[-4]
                reports_raw = row[-3]
                path_raw = row[-2]
                sal_raw = row[-1]
            reports_clean = "".join(c for c in sanitize_text(reports_raw) if c.isdigit()) or ""
            emp_rows.append(
                {
                    "employee_id": sanitize_text(row[0]),
                    "last_name": sanitize_text(row[1]),
                    "first_name": sanitize_text(row[2]),
                    "title": sanitize_text(row[3]),
                    "title_of_courtesy": sanitize_text(row[4]),
                    "birth_date": sanitize_text(row[5]),
                    "hire_date": sanitize_text(row[6]),
                    "address": sanitize_text(row[7]),
                    "city": sanitize_text(row[8]),
                    "region": sanitize_text(row[9]),
                    "postal_code": sanitize_text(row[10]),
                    "country": sanitize_text(row[11]),
                    "home_phone": sanitize_text(row[12]),
                    "extension": sanitize_text(row[13]),
                    "notes": sanitize_text(notes_raw, max_len=8000),
                    "reports_to": reports_clean,
                    "photo_path": sanitize_text(path_raw),
                    "salary": parse_salary(sal_raw),
                }
            )
    fp = OUT / "employees.csv"
    write_csv(
        fp,
        [
            "employee_id",
            "last_name",
            "first_name",
            "title",
            "title_of_courtesy",
            "birth_date",
            "hire_date",
            "address",
            "city",
            "region",
            "postal_code",
            "country",
            "home_phone",
            "extension",
            "notes",
            "reports_to",
            "photo_path",
            "salary",
        ],
        emp_rows,
    )
    outputs["employees.csv"] = {"rows": len(emp_rows), "sha256": sha256_file(fp)}

    # --- shippers ---
    p = next(SRC.glob(patterns["shippers"]))
    _, rows = read_csv_dict(p)
    sh_rows = []
    for r in rows:
        sh_rows.append(
            {
                "shipper_id": sanitize_text(r.get("ShipperID", "")),
                "company_name": sanitize_text(r.get("CompanyName", "")),
                "phone": sanitize_text(r.get("Phone", "")),
            }
        )
    fp = OUT / "shippers.csv"
    write_csv(fp, ["shipper_id", "company_name", "phone"], sh_rows)
    outputs["shippers.csv"] = {"rows": len(sh_rows), "sha256": sha256_file(fp)}

    MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST.write_text(json.dumps({"outputs": outputs}, indent=2), encoding="utf-8")
    print(f"Wrote seeds to {OUT} and manifest {MANIFEST}")


if __name__ == "__main__":
    main()
