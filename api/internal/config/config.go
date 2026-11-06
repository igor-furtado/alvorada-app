package config

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

type Config struct {
	Port            int
	DatabaseHost    string
	DatabasePort    int
	DatabaseName    string
	DatabaseUser    string
	DatabasePass    string
	ShutdownTimeout time.Duration
}

func FromEnvironment() (Config, error) {
	port, err := intFromEnv("PORT", 8080)
	if err != nil {
		return Config{}, err
	}
	databasePort, err := intFromEnv("DB_PORT", 3306)
	if err != nil {
		return Config{}, err
	}

	return Config{
		Port:            port,
		DatabaseHost:    stringFromEnv("DB_HOST", "127.0.0.1"),
		DatabasePort:    databasePort,
		DatabaseName:    stringFromEnv("DB_NAME", "estudos"),
		DatabaseUser:    stringFromEnv("DB_USER", "estudos"),
		DatabasePass:    stringFromEnv("DB_PASSWORD", "estudos"),
		ShutdownTimeout: 10 * time.Second,
	}, nil
}

func (c Config) Address() string {
	return fmt.Sprintf(":%d", c.Port)
}

func stringFromEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

func intFromEnv(key string, fallback int) (int, error) {
	value := os.Getenv(key)
	if value == "" {
		return fallback, nil
	}
	parsed, err := strconv.Atoi(value)
	if err != nil {
		return 0, fmt.Errorf("invalid %s: %w", key, err)
	}
	return parsed, nil
}
