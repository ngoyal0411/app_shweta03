
FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build-env
WORKDIR /app

# Copy csproj and restore
COPY DevOpsAssignment/DevOpsAssignment.csproj ./
RUN dotnet restore

# Copy others and build
COPY . .
RUN dotnet build -c Release -o out

# Build image
FROM mcr.microsoft.com/dotnet/aspnet:3.1
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "DevOpsAssignment.dll"]