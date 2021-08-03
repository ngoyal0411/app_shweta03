
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build-env
WORKDIR /app

# Copy csproj and restore
COPY DevOpsAssignment/DevOpsAssignment.csproj ./
RUN dotnet restore

# Copy others and build
COPY . .
RUN dotnet build -c Release -o out

# Build image
FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "DevOpsAssignment.dll"]