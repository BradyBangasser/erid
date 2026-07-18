package main

import "fmt"

func generate_hostname(ip string, region string, country string, cat string, domain string) string {
	return fmt.Sprintf("%s-%d.%s.%s.%s", cat, 0, region, country, domain)
}
