package middleware

import (
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func CORS() gin.HandlerFunc {
	config := cors.DefaultConfig()
	// 允许特定域名跨域访问
	config.AllowOrigins = []string{
		"https://ai-dev.mrpzx.cn",
		"https://aiwritting.mrpzx.cn",
		"http://ai-dev.mrpzx.cn",
		"http://aiwritting.mrpzx.cn",
		"http://localhost:3000",
		"http://localhost:3002",
		"http://localhost:5173", // Vite开发服务器
		"https://localhost:3000",
		"https://localhost:3002",
	}
	config.AllowCredentials = true
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"}
	config.AllowHeaders = []string{
		"Origin",
		"Content-Type", 
		"Accept",
		"Authorization",
		"X-Requested-With",
		"X-Real-IP",
		"X-Forwarded-For",
		"X-Forwarded-Proto",
		"User-Agent",
		"Referer",
	}
	config.ExposeHeaders = []string{
		"Content-Length",
		"Content-Type",
		"Set-Cookie",
	}
	return cors.New(config)
}
