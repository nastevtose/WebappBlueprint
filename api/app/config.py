from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    database_url: str = "sqlite+aiosqlite:///./data.db"
    cors_origins: list[str] = ["http://localhost:5173", "http://localhost:8080"]
    environment: str = "development"

    # Auth
    secret_key: str = "change-me-in-production"
    google_client_id: str = ""
    google_client_secret: str = ""
    frontend_url: str = "http://localhost:5173"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()
