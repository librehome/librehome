// HTTP client API test.
export function TestHttpClient(url: string) {
    const header: LibertasHttpHeader[] = [
        ["Accept", "*/*"],
        ["User-Agent", "LibertasHub/1.0"],
    ]
    const fd = Libertas_NetNewHttp();
    Libertas_SetOnNetError(fd, (tag, fd, errCode, httpStatus, text) => {
        // TODO:
    }, undefined);
    Libertas_SetOnNetHttpResponse(fd, (t, fd, res) => {
        // TODO: res.statusCode, res.body etc 
    }, undefined);
    Libertas_NetHttpAddRequest(fd,
        "GET",
        url, // HTTP or HTTPS
        header);
    Libertas_WaitReactive();
}
