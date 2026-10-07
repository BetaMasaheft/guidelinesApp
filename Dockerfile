ARG EXIST_VERSION=release

FROM duncdrum/existdb:${EXIST_VERSION}

ADD https://github.com/BetaMasaheft/guidelines/releases/latest/download/guidelines-data.xar /exist/autodeploy/001.xar
ADD https://github.com/BetaMasaheft/Schema/releases/latest/download/betamas-schemas.xar /exist/autodeploy/002.xar


COPY build/*.xar /exist/autodeploy/

# We might want to switch to exploded images for faster deployments later