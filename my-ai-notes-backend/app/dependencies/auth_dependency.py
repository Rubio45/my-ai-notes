from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer

from core.security import decode_access_token
from repos.v1.auth import TokenBlacklistDataSource

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

_blacklist_ds = TokenBlacklistDataSource()


async def get_current_user_id(token: str = Depends(oauth2_scheme)) -> str:
    payload = decode_access_token(token)
    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido o expirado",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if await _blacklist_ds.is_blacklisted(token):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Sesión cerrada. Inicia sesión de nuevo.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    user_id: str | None = payload.get("sub")
    if user_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user_id
