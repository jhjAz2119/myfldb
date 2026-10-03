# routers 接口路由包
from .user_router import router as user_router
from .admin_router import router as admin_router

__all__ = ["user_router", "admin_router"]